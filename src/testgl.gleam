import gleam/list
import gleam/option.{None, Some}
import gleam/regexp.{Options}
import gleam/result
import gleam/string
import simplifile.{type FileError}

pub type DataProvider {
  DataProvider(
    // The name of the DataProvider function minus the '_data_provider' suffix.
    name: String,
    // The module the data provide appears in. E.g. 'internal/string_extra'.
    module: String,
  )
}

pub fn main() -> Nil {
  echo find_data_providers()
  Nil
}

pub fn find_data_providers() -> Result(List(DataProvider), FileError) {
  use gleam_files <- result.try(find_gleam_files_in_directory("test"))
  let #(data_providers, errors) =
    gleam_files |> list.map(get_data_providers_from_file) |> result.partition
  case errors {
    [error, ..] -> Error(error)
    [] -> Ok(list.flatten(data_providers))
  }
}

fn get_data_providers_from_file(
  filename: String,
) -> Result(List(DataProvider), FileError) {
  let assert Ok(data_provider_regexp) =
    regexp.compile(
      "pub fn ([a-z0-9_]+)_data_provider\\(\\)",
      with: Options(multi_line: False, case_insensitive: False),
    )
  use content <- result.try(simplifile.read(filename))
  regexp.scan(with: data_provider_regexp, content: content)
  |> list.map(fn(match) {
    DataProvider(
      module: string.slice(
        filename,
        string.length("test/"),
        string.length(filename)
          - string.length("test/")
          - string.length(".gleam"),
      ),
      name: list.first(match.submatches)
        |> result.lazy_unwrap(fn() {
          panic as "there was no submatch for the data_provider name"
        })
        |> option.lazy_unwrap(fn() { panic as "the submatch was empty" }),
    )
  })
  |> Ok
}

/// Returns a list of relative paths to gleam files in the specified directory
pub fn find_gleam_files_in_directory(
  directory: String,
) -> Result(List(String), FileError) {
  use filenames <- result.try(simplifile.read_directory(directory))
  let files = filenames |> list.map(string.append(directory <> "/", _))
  let gleam_files =
    list.filter(files, fn(file) { string.ends_with(file, ".gleam") })
  let directory_results =
    list.map(files, fn(file) {
      simplifile.is_directory(file)
      |> result.map(fn(bool) {
        case bool {
          True -> Some(file)
          False -> None
        }
      })
    })
    |> list.filter(fn(directory_result) {
      result.is_error(directory_result)
      || result.map(directory_result, option.is_some)
      |> result.unwrap(False)
    })
    |> list.map(result.map(_, option.unwrap(_, "")))

  use directories <- result.try(unwrap_results(directory_results))
  let subdirectory_gleam_file_results =
    directories |> list.map(find_gleam_files_in_directory)
  use subdirectory_gleam_files <- result.try(unwrap_results(
    subdirectory_gleam_file_results,
  ))
  Ok(list.append(gleam_files, list.flatten(subdirectory_gleam_files)))
}

fn unwrap_results(results: List(Result(t, e))) -> Result(List(t), e) {
  let #(items, errors) = results |> result.partition
  case errors {
    [error, ..] -> Error(error)
    [] -> Ok(items)
  }
}
