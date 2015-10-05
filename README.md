# RailsPowergrid

![Travis CI](https://travis-ci.org/anykeyh/rails_powergrid.svg)

Create grids into your rails application with no pain.

Easily customizable, built-in with filtering, sorting, cell-edition, infinite-scrolling etc...


# Demo

TODO. You can checkout the [demo](https://github.com/anykeyh/demo_powergrid).

# Installation

1 - Add theses lines to your gemfile:

```ruby
  gem 'rails_powergrid', git: "https://github.com/anykeyh/rails_powergrid.git", branch: "master"
  gem "compass-rails", github: "Compass/compass-rails", branch: "master"
```

2 - Route the controller

In `config/routes.rb`

```ruby
Rails.application.routes.draw do
  #...
  rails_powergrid
  #...
end
```

3 - Includes the assets

In `app/assets/javascript/application.js`

```javascript
//= require rails_powergrid
```

In `app/assets/stylesheets/application.css`

```css
 /*= require powergrid */
```

(Note: You can use `@import "powergrid"` if your file is in scss)

# Usage

TODO

##What's the dependencies?

Mostly ReactJS and Compass. Compass dependency will be removed in a near future.
