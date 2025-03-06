local TreesitterQuery = {}

TreesitterQuery.value = [[

;; Capture parameter sources for parameterized tests in Kotlin
(
  (function_declaration
    (modifiers
      (annotation
       (constructor_invocation
        (user_type)@AnnotationFunctionName 
       )@test.name
      )@annotation
    )@annotions
  ) @test.definition
  (function_body)@function.body (#match? @AnnotationFunctionName "ParameterizedTest")
)

]]
return TreesitterQuery
