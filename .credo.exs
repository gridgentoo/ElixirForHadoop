# This file contains the configuration for Credo.
#
# If you find anything wrong or unclear in this file, please report an
# issue on GitHub: https://github.com/rrrene/credo/issues
%{
  #
  # You can have as many configs as you like in the `configs:` field.
  configs: [
    %{
      #
      # Run any config using `mix credo -C <name>`. If no config name is given
      # "default" is used.
      name: "default",
      #
      # these are the files included in the analysis
      files: %{
        #
        # you can give explicit globs or simply directories
        # in the latter case `**/*.{ex,exs}` will be used
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: []
      },
      #
      # The `checks:` field contains all the checks that are run. You can
      # customize the parameters of any given check by adding a second element
      # to the tuple.
      #
      # There are two ways of deactivating a check:
      # 1. deleting the check from this list
      # 2. putting `false` as second element (to quickly "comment it out"):
      #
      #      {Credo.Check.Consistency.ExceptionNames, false}
      #
      checks: [
        {Credo.Check.Consistency.ExceptionNames},
        {Credo.Check.Consistency.LineEndings, false},
        {Credo.Check.Consistency.SpaceAroundOperators},
        {Credo.Check.Consistency.SpaceInParentheses, false},
        {Credo.Check.Consistency.TabsOrSpaces},

        # For some checks, like AliasUsage, you can only customize the priority
        # Priority values are: `low, normal, high, higher`
        {Credo.Check.Design.AliasUsage, priority: :low},
        # For others you can set parameters
        {Credo.Check.Design.DuplicatedCode, mass_threshold: 16, nodes_threshold: 2},

        # You can also customize the exit_status of each check.
        # If you don't want TODO comments to cause `mix credo` to fail, just
        # set this value to 0 (zero).
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Design.TagFIXME},

        {Credo.Check.Readability.FunctionNames},
        {Credo.Check.Readability.MaxLineLength, priority: :low, max_length: 80},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc},
        {Credo.Check.Readability.ModuleNames},
        {Credo.Check.Readability.ParenthesesInCondition, false},
        {Credo.Check.Readability.PredicateFunctionNames},
        {Credo.Check.Readability.TrailingBlankLine},
        {Credo.Check.Readability.TrailingWhiteSpace},
        {Credo.Check.Readability.VariableNames},

        {Credo.Check.Refactor.ABCSize, max_size: 50},
        {Credo.Check.Refactor.CaseTrivialMatches},
        {Credo.Check.Refactor.CondStatements},
        {Credo.Check.Refactor.FunctionArity},
        {Credo.Check.Refactor.MatchInCondition, false},
        {Credo.Check.Refactor.PipeChainStart},
        {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 12},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting, max_nesting: 3},
        {Credo.Check.Refactor.UnlessWithElse},

        {Credo.Check.Warning.IExPry},
        {Credo.Check.Warning.IoInspect},
        {Credo.Check.Warning.NameRedeclarationByAssignment, false},
        {Credo.Check.Warning.NameRedeclarationByCase, false},
        {Credo.Check.Warning.NameRedeclarationByDef},
        {Credo.Check.Warning.NameRedeclarationByFn, false},
        {Credo.Check.Warning.OperationOnSameValues},
        # Unable to detect when Enum op is last in a function
        {Credo.Check.Warning.UnusedEnumOperation, false},
        {Credo.Check.Warning.UnusedKeywordOperation},
        {Credo.Check.Warning.UnusedListOperation},
        {Credo.Check.Warning.UnusedStringOperation},
        {Credo.Check.Warning.UnusedTupleOperation},
        {Credo.Check.Warning.OperationWithConstantResult},
      ]
    }
  ]
}
