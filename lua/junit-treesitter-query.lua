local TreesitterQuery = {}

TreesitterQuery.value = [[

;; Capture Kotlin test functions with @Test and @ParameterizedTest annotations
(
  (function_declaration
    (modifiers
      (annotation
       (constructor_invocation
        (user_type) @AnnotationFunctionName
        (value_arguments (string_literal) @test.name)?
       )
      )
    )
    name: (simple_identifier) @test.name
  ) @test.definition
  (function_body) @function.body (#match? @AnnotationFunctionName "ParameterizedTest")
)

]]
return TreesitterQuery
