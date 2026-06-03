import gleam/string

pub fn test_string_upper_case_converts_lowercase_to_uppercase_data_provider() {
  #(#("hello", "HELLO"), #("from", "FROM"), #("testgl!", "TESTGL!"))
}

pub fn test_string_upper_case_converts_lowercase_to_uppercase(
  test_case: #(String, String),
) {
  assert string.uppercase(test_case.0) == test_case.1
}
