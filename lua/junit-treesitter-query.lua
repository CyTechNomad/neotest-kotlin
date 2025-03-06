local TreesitterQuery = {}

TreesitterQuery.value = [[

;; Capture Kotlin test functions with @Test annotations
(function_declaration
    (modifiers
      (annotation
        (constructor_invocation
          (user_type (type_identifier) @annotation_name (#eq? @annotation_name "Test"))))
    (simple_identifier @test.name)
)@test.definition
]]
return TreesitterQuery
