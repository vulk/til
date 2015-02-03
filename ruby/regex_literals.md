# Regex Literals

Regular expressions in Ruby are typically delineated by the `/` character.
However, this forces you to escape `/` in your expression.

I was recently using a regex to match certain URLs

```ruby
/http:\/\/sub\.domain\.com\/path/
```

A colleague pointed out that I could use the `%r{...}` notation and avoid
escaping all those backslashes.

```ruby
%r{http://sub\.domain\.com/path}
```

Much cleaner!
