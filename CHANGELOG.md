# version 2.2.2
fix for non-ActiveRecord models failing on includes

# version 2.2.1
fix fragments for newer versions `graphql-ruby`

# version 2.2.0
support `graphql-ruby` > 0.8

# version 2.1.0
Add (optional) 'name' parameter to `#generate`

# version 2.0.0
Make a lot of changes, in order to support more recent versions of graphql-ruby.

Breaking Change:
- `#new` was removed. Use `#generate` instead
- `type` argument was renamed to `resolve_type`


# version 1.0.0
Move uuid to an argument instead [#1](https://github.com/brettjurgens/graphql-active-record/pull/1)
