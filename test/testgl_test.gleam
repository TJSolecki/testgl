import data_provider.{DataProvider}
import gleeunit
import testgl

pub fn main() -> Nil {
  testgl.main()
  gleeunit.main()
}

pub fn get_data_providers_finds_test_example_data_providers_test() -> Nil {
  assert testgl.get_data_providers("test/")
    == Ok([
      DataProvider(
        name: "test_string_upper_case_converts_lowercase_to_uppercase",
        module: "test_data/data_provider_example",
        num_test_cases: 3,
      ),
    ])
}
