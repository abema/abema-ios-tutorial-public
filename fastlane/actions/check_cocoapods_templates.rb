require 'json'

module Fastlane
  module Actions
    class CheckCocoapodsTemplatesAction < Action

      def self.run(params)
        unless system "diff", "Podfile.lock", "Pods/Manifest.lock"
          UI.user_error! 'Pods ディレクトリが最新ではありません。 `make pod-install` を実行してください'
        end

        failed = false

        xcodegen = JSON.parse(`make xcodegen-dump`)
        xcodegen_targets = xcodegen["targets"]

        support_files_template = "Pods/Target Support Files/Pods-"
        support_files = Dir.glob("#{support_files_template}*")
        for support_file in support_files do
          target_name = support_file.delete_prefix support_files_template
          has_frameworks = ! Dir.glob("#{support_file}/Pods-#{target_name}-frameworks-*.xcfilelist").empty?
          has_resources = ! Dir.glob("#{support_file}/Pods-#{target_name}-resources-*.xcfilelist").empty?

          unless xcodegen_targets.key? target_name
            UI.important "ターゲット '#{target_name}' が定義されていません"
            next
          end

          target = xcodegen_targets[target_name]
          templates = target.fetch("templates", [])

          unless templates.include? "CocoaPods"
            UI.error "ターゲット '#{target_name}' に 'CocoaPods' テンプレートを追加してください"
            failed = true
          end

          if has_frameworks && !(templates.include? "CocoaPodsFrameworks")
            UI.error "ターゲット '#{target_name}' に 'CocoaPodsFrameworks' テンプレートを追加してください"
            failed = true
          end

          if has_resources && !(templates.include? "CocoaPodsResources")
            UI.error "ターゲット '#{target_name}' に 'CocoaPodsResources' テンプレートを追加してください"
            failed = true
          end
        end

        if failed
          UI.user_error! "不足しているテンプレートがあります"
        else
          UI.success "テンプレートは正しく設定されています"
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "XcodeGen用のプロジェクト定義にCocoaPodsテンプレートが正しく設定されているかを確認する"
      end
    end
  end
end
