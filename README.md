# TestGL

A testing library which adds Java's TestNG's @DataProvider pattern to gleam.

## Usage

To setup test GL, add the following to your `test/<package_name>_test.gleam` file

```gleam
import gleeunit
import testgl

pub fn main() -> Nil {
    testgl.main()
    gleeunit.main()
}
```

TestGL will search for public gleam function in `.gleam` files in your test directory that end with `_data_provider` that
return an `Tuple` of test data. Each data provider should have an associated function with the same name sans the
`_data_provider` suffix that accepts the inner type of the `Tuple` and performs a test. Here is an example:

```gleam
pub fn to_upper_should_convert_lowercase_to_uppercase_data_provider() {
    #(
        #("hello", "HELLO"),
        #("from", "FROM"),
        #("testgl!", "TESTGL!")
    )
}

pub fn to_upper_should_convert_lowercase_to_uppercase(test_case: #(String, String)) {
    assert string.to_upper(test_case.0) == test_case.1
}
```

TestGL will pick up these functions and transform them into the following 3 test cases in a generated file
`test/to_upper_should_convert_lowercase_to_uppercase.gleam`.

```gleam
import string_test

pub fn to_upper_should_convert_lowercase_to_uppercase_0_test() {
    string_test.to_upper_should_convert_lowercase_to_uppercase_data_provider().0
    |> string_test.to_upper_should_convert_lowercase_to_uppercase
}

pub fn to_upper_should_convert_lowercase_to_uppercase_1_test() {
    string_test.to_upper_should_convert_lowercase_to_uppercase_data_provider().1
    |> string_test.to_upper_should_convert_lowercase_to_uppercase
}

pub fn to_upper_should_convert_lowercase_to_uppercase_2_test() {
    string_test.to_upper_should_convert_lowercase_to_uppercase_data_provider().2
    |> string_test.to_upper_should_convert_lowercase_to_uppercase
}
```
