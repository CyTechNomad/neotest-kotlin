local TreesitterQuery = {}

TreesitterQuery.value = [[

;; Capture Kotlin test functions with @Test and @ParameterizedTest annotations
(
  (function_declaration
    name: (simple_identifier) @test.name
    body: (function_body) @function.body
    (modifiers
      (annotation
       (constructor_invocation
        (user_type) @AnnotationFunctionName
       )
      )
    )
  ) @test.definition
  (#match? @AnnotationFunctionName "Test$|ParameterizedTest") ;; Match both @Test and @ParameterizedTest
)

]]
return TreesitterQuery
