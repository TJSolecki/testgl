pub type DataProvider {
  DataProvider(
    // The name of the DataProvider function minus the '_data_provider' suffix.
    name: String,
    // The module the data provide appears in. E.g. 'internal/string_extra'.
    module: String,
    // The number of test cases returned by the data provider
    num_test_cases: Int,
  )
}
