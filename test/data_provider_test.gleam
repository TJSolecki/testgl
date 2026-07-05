import data_provider.{DataProvider}
import simplifile

pub fn empty_data_provider_test() {
  assert data_provider.to_test_source(DataProvider(
      module: "",
      num_test_cases: 0,
      name: "",
    ))
    == ""
}

pub fn data_provider_test() {
  let assert Ok(expected) =
    simplifile.read("test/expected_data_providers/uppercase_example")
  assert data_provider.to_test_source(DataProvider(
      module: "string_test",
      num_test_cases: 3,
      name: "string_upper_case_converts_lowercase_to_uppercase",
    ))
    == expected
}

pub fn data_provider_with_one_case_test() {
  let assert Ok(expected) =
    simplifile.read("test/expected_data_providers/one_case")
  assert data_provider.to_test_source(DataProvider(
      module: "foo/bar",
      num_test_cases: 1,
      name: "foo",
    ))
    == expected
}
