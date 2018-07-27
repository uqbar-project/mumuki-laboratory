module Solvable
  def submit_solution!(user, attributes={})
    assignment, _ = find_assignment_and_submit! user, attributes[:content].to_mumuki_solution(language)
    try_solve_discussions(user) if assignment.passed?
    assignment
  end

  def run_tests!(params, custom_test = nil)
    language.run_tests!(
      params.merge(
        test: custom_test || test,
        locale: locale,
        expectations: expectations))
  end
end

class NilClass
  def to_mumuki_solution(language)
    Solution.new
  end
end

class String
  def to_mumuki_solution(language)
    Solution.new content: normalize_whitespaces
  end
end

class Hash
  def to_mumuki_solution(language)
    language
      .directives_sections
      .join(self)
      .to_mumuki_solution(language)
  end
end
