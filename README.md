# Footgauntlet

## Footgauntlet Core
Design docs for the domain core of any shell application can be found here:
[lib/footgauntlet/core/DESIGN.md](lib/footgauntlet/core/DESIGN.md)

## Brod
!["Can you pass the salt?"](https://imgs.xkcd.com/comics/the_general_problem.png)
Design docs for the underyling stream processing framework Brod can be found here:
[lib/footgauntlet/utils/brod/DESIGN.md](lib/footgauntlet/utils/brod/DESIGN.md)

## Prerequisites
Before you can run the tests, you'll need to ensure some prerequisites are
satisfied.

Have the following installed on your system: 
- Ruby (version specified in the `Gemfile`, e.g., `3.2.2`)
- Bundler (the dependency manager for Ruby projects)

You can use a Ruby version manager to manage multiple Ruby versions on your
system:
- [asdf](https://asdf-vm.com/).
- [RVM](https://rvm.io/)
- [rbenv](https://github.com/rbenv/rbenv)

Next, install dependencies with:
```
bundle install
```

## Running the tests
```
bundle exec rake
```

## Full e2e test
```
./bin/e2e
```