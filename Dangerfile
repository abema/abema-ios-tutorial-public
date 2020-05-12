def fail_if_master
    is_master_pr = github.branch_for_base == 'master'
    master_in_title = github.pr_title.include? '[master]'

    if is_master_pr && !master_in_title
        fail "Pull Requestの向き先（base branch）を変更してください。masterに変更を加える場合は、タイトルに [master] を含めてください。"
    end
end

swiftlint.lint_files inline_mode: true, fail_on_error: true
fail_if_master