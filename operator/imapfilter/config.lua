options.timeout = 120

myaccount = IMAP {
    server = 'imap.example.com', -- TODO: change it
    username = 'john.doe@example.com', -- TODO: change it
    password = '...', -- TODO: change it
    ssl = 'ssl23' -- this might be unnecessary in your particular case
}

function confirm_transaction(id)
    local composeFile = '/opt/freeton-toolbox/tonos-cli/docker-compose.yml'
    local msigAddress = '-1:...' -- TODO: change it
    local custodianKeys = '/opt/freeton-toolbox/.secrets/deploy.keys.json' -- TODO: make sure that file is the right one
    local command = string.format([[
        docker-compose -f "%s" run -T --rm \
            -v '%s:/opt/tonos-cli/deploy.keys.json:ro' \
            tonos-cli-dev call %s confirmTransaction '{"transactionId":"%s"}'
    ]], composeFile, custodianKeys, msigAddress, id)

    print('command: ' .. command)

    for n = 1,3 do -- try several times in case of failure
        if os.execute(command) then
            break
        end
    end
end

results = myaccount.INBOX:is_unseen() *
          myaccount.INBOX:contain_from('john.doe@example.com') -- TODO: change it

results:mark_seen()

for _, msg in ipairs(results) do
    local mbox, uid = table.unpack(msg)
    local body = mbox[uid]:fetch_body()
    local id = string.match(body, '"transId": "(0x%x+)"')

    if id then
        confirm_transaction(id);
    end
end

