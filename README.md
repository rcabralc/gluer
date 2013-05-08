# Gluer

A configuration reload tool.  Useful when you want to keep registration code
next to the objects being registered, in an enviroment where another library is
already doing code reload for you.  Gluer provides you a way to unregister and
re-register configuration code as the code's file is reloaded.

## Installation

Add this line to your application's Gemfile:

    gem 'gluer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gluer

## Usage

Let's suppose you are using a library which holds registrations in a global
registry and its usage is something along these lines:

```ruby
class MyFoo
end

FooRegistry.add_foo(MyFoo, as: 'bar') { MyBaz.init! }
```

This is simple and harmless, until you start to use some tool or lib to reload
code for you, like ActiveSupport.  If that line is put in a file which is
reloaded in every request in your app (in dev mode) you'll end up with many
registrations of `MyFoo` as a foo.  The way Gluer allows you to escape from
this is by enclosing the registration code in a block:

```ruby
class MyFoo
end

Gluer.setup(MyFoo) do
  add_foo 'bar' { MyBaz.init! }
end
```

But firstly, you must configure Gluer in order to make it recognize that
``add_foo``.  If you are using Rails, this goes well in an initializer file, or
in a place where you are sure that `MyFoo`'s file was not loaded yet:

```ruby
Gluer.define_registration :add_foo do |registration|
  registration.on_commit do |registry, context, arg, &block|
    registry.add_foo(context, as: arg, &block)
  end

  registration.on_rollback do |registry, context, arg, &block|
    registry.remove_foo(context, as: arg, &block)
  end

  registration.registry { FooRegistry }
end
```

Next, in a place that runs early in every request (like a ``before_filter`` in
`ApplicationController`, if you're using Rails):

```ruby
Gluer.reload
```

When the file containing `MyFoo` is reloaded, the previous registration is
rolled back, and a new registration is done.  This keeps the registry
`FooRegistry` free of repetitions.  In fact, you must know that `Gluer.reload`
will load that file, instead of letting your reloader lib do that for you
lazily.

The commit hook is called when the registration is to be performed.  `registry`
is, as you may guess, is the `FooRegistry` object.  `context` is the argument
given to `Gluer.setup`, in this case the `MyFoo` class object.  All remaining
arguments and block are forwarded from the call to ``add_foo`` in
`Gluer.setup`'s block.

The rollback hook receives the same arguments as the commit hook.

## Caveats

1. `FooRegistry` must provide a way to unregister.
2. It uses `grep` to get the files with `Gluer.setup`. Probably a problem in
   Windows. I did not test.
3. Loads the found files eagerly. So, you should account for the side effects
   of this.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
