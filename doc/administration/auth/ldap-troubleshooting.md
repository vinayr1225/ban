# LDAP Troubleshooting

The following commands are for features available in GitLab Starter.

## Rails console debugging

Here are some rails console commands you can run to help debug problems you're
running into with LDAP. Please note that these commands are all READ-ONLY so
they won't make any permanent changes.

Enter the rails console with `gitlab-rails console`.

### Get debug output

This will provide a greater level of debug output that can be useful to see
what GitLab is doing and with what. This value is not persisted.

```ruby
Rails.logger.level = Logger::DEBUG
```

### UserSync

Run a [user sync]() and watch the output for what GitLab finds in LDAP and
what it does with it. This requires the [debug output](#get-debug-output) be
enabled.

This can be helpful when debugging why a particular user isn't getting found.

```ruby
LdapSyncWorker.new.perform
```

### GroupSync

#### Sync all groups

```ruby
LdapAllGroupsSyncWorker.new.perform
```

#### Sync one group

```ruby
group = Group.find_by(name: 'my_gitlab_group')
EE::Gitlab::Auth::LDAP::Sync::Group.execute_all_providers(group)
```

```ruby
# Query an LDAP group directly
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain') # If `main` is the LDAP provider
ldap_group = EE::Gitlab::Auth::LDAP::Group.find_by_cn('group_cn_here', adapter)
ldap_group.member_dns
ldap_group.member_uids

# Lookup a particular user (10.6+)
# This could expose potential errors connecting to and/or querying LDAP that may seem to
# fail silently in the GitLab UI
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain') # If `main` is the LDAP provider
user = Gitlab::Auth::LDAP::Person.find_by_uid('<username>',adapter)

# Query the LDAP server directly (10.6+)
## For an example, see https://gitlab.com/gitlab-org/gitlab-ee/blob/master/ee/lib/ee/gitlab/auth/ldap/adapter.rb
adapter = Gitlab::Auth::LDAP::Adapter.new('ldapmain')
options = {
    # the :base is required
    # use adapter.config.base for the base or .group_base for the group_base
    base: adapter.config.group_base,

    # :filter is optional
    # 'cn' looks for all "cn"s under :base
    # '*' is the search string - here, it's a wildcard
    filter: Net::LDAP::Filter.eq('cn', '*'),

    # :attributes is optional
    # the attributes we want to get returned
    attributes: %w(dn cn memberuid member submember uniquemember memberof)
}
adapter.ldap_search(options)
```

### Update user accounts when the `dn` and email change

The following will require that any accounts with the new email address are removed.  Emails have to be unique in GitLab.  This is expected to work but unverified as of yet.

```ruby
# Here's an example with a couple users.
# Each entry will have to include the old username and the new email
emails = {
  'ORIGINAL_USERNAME' => 'NEW_EMAIL_ADDRESS',
  ...
}

emails.each do |username, email|
  user = User.find_by_username(username)
  user.email = email
  user.skip_reconfirmation!
  user.save!
end

# Run a UserSync to sync the above users' data
LdapSyncWorker.new.perform
```

