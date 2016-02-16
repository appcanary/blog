PROJECT_ROOT = File.join(File.dirname(__FILE__))
BUILD_DIR = File.join(PROJECT_ROOT, "build")
GH_PAGES_REF = File.join(BUILD_DIR, ".git/refs/heads/gh-pages")

file GH_PAGES_REF do
  cd PROJECT_ROOT do
    sh "rm -rf #{BUILD_DIR}"

    sh "git clone -b gh-pages git@github.com:appcanary/blog.git build"
  end
end

task :build => GH_PAGES_REF do
  cd PROJECT_ROOT do
    sh "git pull"
    sh "bundle exec middleman build --no-clean"
  end
end

task :not_dirty do
  cd PROJECT_ROOT do
    fail "Directory not clean" if /nothing to commit/ !~ `git status`
  end
end

task :deploy => [:not_dirty, :build] do
  cd PROJECT_ROOT do
    head = `git log --pretty="%h" -n1`.strip
    message = ["Site updated to #{head}"].compact.join("\n\n")

    cd BUILD_DIR do
      sh 'git add --all'
      if /nothing to commit/ =~ `git status`
        puts "No changes to commit."
      else
        sh "git commit -m \"#{message}\""
      end
      sh "git push origin gh-pages"
    end
  end
end
