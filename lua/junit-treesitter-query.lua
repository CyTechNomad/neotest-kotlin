local TreesitterQuery = {}

TreesitterQuery.value = [[
;; testes
;; Capture parameter sources for parameterized tests in Kotlin
(
  (function_declaration
    (modifiers
      (annotation
       (constructor_invocation
        (user_type)@AnnotationFunctionName
        (#match? @AnnotationFunctionName "ParameterizedTest")
       )@test.name
      )@annotation
    )@annotions
  ) @test.definition
)

]]
return TreesitterQuery
