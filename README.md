# hash_tools

Do things to Hashes, without injecting methods into them or extending core classes of the language.
And mostly without being too smart. Does not require ActiveSupport.

Transforming the keys of a hash:

    HashTools::Transform.transform_keys_of({'foo' => 1}, &:upcase) #=> {'FOO' => 1}, works recursively

Fetching multiple values from a Hash:

    h = {
      'foo' => {
        'bar' => 2
        'baz' => 1
      }
    }
    HashTools.deep_fetch(h, 'foo/bar') #=> 2
    HashTools.deep_fetch_multi(h, 'foo/bar', 'foo/baz') #=> [2, 1]

Fetching multiple values from arrays of Hashes

    records = [
      {'name': 'Jake'},
      {'name': 'Barbara'},
    ]
    
    HashTools.deep_map_value(records, 'name') #=> ['Jake', 'Barbara']

A simple indifferent access proxy:

    h = {'foo'=>{bar: 2}}
    w = HashTools.indifferent(h)
    w[:foo][:bar] #=> 2

Check the documentation for the separate modules for more.

## Contributing to hash_tools
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2015 Julik Tarkhanov. See LICENSE.txt for
further details.

