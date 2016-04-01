# DatabasePlumber [![Build Status](https://travis-ci.org/brrygrdn/database_plumber.svg?branch=v0.0.1)](https://travis-ci.org/brrygrdn/database_plumber)

A common problem in test suites for large [Rails][rails] applications is that,
as they mature, balancing test speed and complexity often results in heavy use
of tools like [FactoryGirl][factorygirl] and [DatabaseCleaner][databasecleaner].

These are powerful and useful tools, but over time it often becomes evident that
large factories can create and orphan many rows in the database; combine with the
need for non-transactional database maintenance during [Capybara][capybara] tests
and its very easy to be plagued by mystery guests.

DatabasePlumber is a quick utility that checks for rows left after an example
group has been executed, publishes a report and cleans up.

## Why use this?

Well, for starters, it acts as a quick sticking plaster on the problem of mystery
guests, giving you back confidence in your CI runs in the short term.

Long-term, it removes the fear from optimizing the persistence of objects using
[RSpec][rspec] `before(:all)` blocks by making it clear when you, or your factories
have not cleaned up properly after.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'database_plumber', github: 'brrygrdn/database_plumber'
```

And then execute:

    $ bundle


## Usage

To get started, add the following lines to your `spec_helper.rb`

```ruby
RSpec.configure do |config|

  ...

  config.after(:each) do |example|
    DatabaseCleaner.clean
    # Notify DatabasePlumber of each example after it has been executed
    DatabasePlumber.log example
  end

  config.after(:all) do
    # Perform the report after each example group
    DatabasePlumber.inspect
  end

  ...

end
```

Run your tests as normal, and you'll see a report after any examples:

```
> bundle exec rspec spec/models/
.....
#### Leaking Test

  The spec './spec/models/foo_spec.rb' leaves
  the following rows in the database:

     - 1 row(s) for the Foo model
     - 5 row(s) for the Bar model

#### What now?

  If you are using let! or before(:all) please ensure that you use a
  corresponding after(:all) block to clean up these rows.

..........

Finished in 3.14159 seconds
15 examples, 0 failures

Randomized with seed 17015
```

### Ignoring Models

You may have some models that you don't want to report on, for example a configuration
table that is seeded or loaded with fixtures as part of test suite setup.

```ruby
config.after(:all) do
  # Perform the report after each example group
  DatabasePlumber.inspect ignored_models: [Bar, Baz]
end
```

### Ignoring Databases

You may have models in your application backed by multiple adapters, some of which
may be throw-away after each example group e.g. using SQLite for anonymous models

To exclude all models from a given adapter, you can add the following:

```ruby
config.after(:all) do
  # Perform the report after each example group
  DatabasePlumber.inspect ignored_adapters: [:sqlite]
end
```

If you are unsure of which adapter to ignore, you can check via the Rails console:

```ruby
  > Foo.connection.adapter_name
  'PostgreSQL'
  # The corresponding symbol to use is :postgresql
```

### Halting Tests on a Leak

When debugging a suite with several mystery guests, you can halt immediately
after each leak.

```ruby
config.after(:all) do
  # Perform the report after each example group
  DatabasePlumber.inspect ignored_models: [Bar, Baz],
                          ignored_adapters: [:sqlite],
                          brutal: true
end
```

### Setting thresholds for Models

You may have some models you would like to report on, but which should also have
entries in the database, for example a table that is seeded or loaded with fixtures.
In order to allow this you can provide a threshold for a Model, which is the
maximum number of entries allowed in the database for the Model before it is
regarded as leaky.

To provide a threshold for a Model, you can can the following:

```ruby
config.after(:all) do
  # Perform the report after each example group
  DatabasePlumber.inspect model_thresholds: { Bar => 3 }
end


## Contributing

1. Fork it ( https://github.com/brrygrdn/database_plumber/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[rails]: https://github.com/rails/rails
[factorygirl]: https://github.com/thoughtbot/factory_girl
[databasecleaner]: https://github.com/DatabaseCleaner/database_cleaner
[capybara]: https://github.com/jnicklas/capybara
[rspec]: https://github.com/rspec/rspec
