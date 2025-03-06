local TreesitterQuery = {}

TreesitterQuery.value = [[

;; Capture Kotlin test functions with @Test and @ParameterizedTest annotations
(
  (function_declaration
    (modifiers
      (annotation
        (user_type
            (type_identifier)))) @AnnotationFunctionName
    (simple_identifier @test.name)
       )
      )
    )
  ) @test.definition (#match? @AnnotationFunctionName "Test")
)

]]
return TreesitterQuery
