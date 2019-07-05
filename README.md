# PolymorphicJoin

Rails does not include a polymorphic join by default but this gem would help you to joins your polymorphic relationship with ease.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'polymorphic_join', '~> 0.2.1'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polymorphic_join

## Usage

Include the module inside your model

```
include PolymorphicJoin
```

Then you can use the polymorphic join like followings:

Given that I have this model call `Notification`

```rb
class Notification < ApplicationRecord
  belongs_to :notifiable, polymorphic: true
  include PolymorphicJoin
end
```

Then I can call:

```rb
Notification
  .ref_polymorphic(:notifiable)
  .where('notifiables.common_attribute' => 'test')
  .order('notifiables.common_attribute ASC')
```

Or if I want to specify only those types that I want to reference to:

```rb
Notification
  .ref_polymorphic(
    :notifiable, [:uploads, :comments]
  )
  .where('notifiables.common_attribute' => 'test')
  .order('notifiables.common_attribute ASC')
```

Or if you want to map back certain column

```rb
Notification
  .ref_polymorphic(
    :notifiable,
    [
      :comments,
      {
        uploads: { title: 'content' }
      }
    ]
  )
  .where('notifiables.common_attribute' => 'test')
  .order('notifiables.common_attribute ASC')
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/polymorphic_join. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PolymorphicJoin project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/polymorphic_join/blob/master/CODE_OF_CONDUCT.md).
