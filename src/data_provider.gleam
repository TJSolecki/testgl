import gleam/bool
import gleam/int

pub type DataProvider {
  DataProvider(
    // The name of the DataProvider function minus the '_data_provider' suffix.
    name: String,
    // The module the data provider appears in. E.g. 'internal/string_extra'.
    module: String,
    // The number of test cases returned by the data provider
    num_test_cases: Int,
  )
}

pub const data_provider_fn_suffix = "_data_provider"

pub fn to_test_source(data_provider: DataProvider) -> String {
  use <- bool.guard(data_provider.num_test_cases == 0, "")
  import_line(data_provider)
  <> int.range(
    from: 0,
    to: data_provider.num_test_cases,
    with: "",
    run: fn(acc, i) {
      acc <> "\n\n" <> get_test_case_function(data_provider.name, i)
    },
  )
  <> "\n"
}

fn import_line(data_provider: DataProvider) -> String {
  "import "
  <> data_provider.module
  <> ".{\n"
  <> tab(data_provider.name <> ",\n")
  <> tab(data_provider.name <> data_provider_fn_suffix <> ",\n")
  <> "}"
}

fn get_test_case_function(name: String, num_test_case: Int) -> String {
  "pub fn "
  <> name
  <> "_"
  <> int.to_string(num_test_case)
  <> "_test() {\n"
  <> tab(
    name
    <> data_provider_fn_suffix
    <> "()."
    <> int.to_string(num_test_case)
    <> "\n",
  )
  <> tab("|> " <> name <> "\n")
  <> "}"
}

fn tab(text: String) -> String {
  "  " <> text
}
