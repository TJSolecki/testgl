import glance.{
  type Expression, type Statement, Expression, Function, Public, Tuple,
}
import gleam/bool
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import simplifile.{type FileError}

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
  use content <- result.try(simplifile.read(filename))
  let assert Ok(ast) = glance.module(content)
  list.flat_map(ast.functions, fn(function_definition) {
    let function = function_definition.definition
    use <- bool.guard(
      !string.ends_with(function.name, "_data_provider")
        || function.publicity != Public,
      [],
    )
    let num_test_cases =
      get_returned_tuple_elements(function.body) |> list.length
    use <- bool.guard(num_test_cases == 0, [])
    [
      DataProvider(
        module: string.slice(
          filename,
          string.length("test/"),
          string.length(filename)
            - string.length("test/")
            - string.length(".gleam"),
        ),
        name: string.slice(
          function.name,
          0,
          string.length(function.name) - string.length("_data_provider"),
        ),
        num_test_cases: num_test_cases,
      ),
    ]
  })
  |> Ok
}

fn get_returned_tuple_elements(statements: List(Statement)) -> List(Expression) {
  case statements {
    [Expression(Tuple(elements: elements, ..))] -> elements
    [_, ..rest] -> get_returned_tuple_elements(rest)
    _ -> []
  }
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
