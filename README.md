# domo
_simple domain modeling tool_

## Warning
The parser is awfully written and not documented. It _needs_ a refactor.

## Sample syntax
```
Instrument : Electric | Acoustic | Bass | Ukelele
Course.instrument : Instrument
Course.song : Song
Lesson.video : Video
# Course.lessons : Array(Lesson)
```

## Features

- [x] Parse union types
- [x] Parse member types
- [x] Verify types aren't union and member
- [x] Handle comments
- [ ] Handle generic types

## Contributing

1. Fork it ( https://github.com/Willamin/domo/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [Willamin](https://github.com/Willamin) Will Lewis - creator, maintainer
