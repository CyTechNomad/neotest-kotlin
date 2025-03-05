local TreesitterQuery = {}

TreesitterQuery.value = [[

;; Capture parameter sources for parameterized tests in Kotlin
(
  (function_declaration
    (modifiers
      (annotation
       (constructor_invocation
        (user_type)@AnnotationFunctionName
        (#match? @AnnotationFunctionName "ParameterizedTest")
       )@InvocationOfAnnotation
      )@annotation
    )@annotions
  ) @Tests
)

]]
return TreesitterQuery
