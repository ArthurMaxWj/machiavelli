# README -- prototype
Machiavelli card game implementation for local/single-player and remote versions. 
Hosted at: www.machiavelli-oi6b.onrender.com (**it can take a moment for hosting to awaken the application instance**)

## In progress:
Refactoring specs (use Rubocop Rspec, use factories)

## To-do in the future (maybe):
* use WebSockets/ActionCable instead of AJAX in Remote Sessions (check hosting requirements)
* add frontend/controller tests with Capybara
* maybe use MongoDB?

## How to start
Precompile assets and start server:
```
bundle install
rails assets:precompile
rails s
```