import gleeunit
import testgl.{DataProvider}

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn find_data_providers_finds_test_example_data_providers_test() -> Nil {
  assert testgl.find_data_providers()
    == Ok([
      DataProvider(
        name: "test_string_upper_case_converts_lowercase_to_uppercase",
        module: "test_data/data_provider_example",
        num_test_cases: 3,
      ),
    ])
}
