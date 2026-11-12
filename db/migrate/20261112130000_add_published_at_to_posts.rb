# 記事の「下書き / 公開」を published_at（公開日時）で表す。
# NULL なら下書き、日時が入っていれば公開済み。
# true/false の列ではなく日時にしておくと「いつ公開したか」も分かり、一覧の並び順にも使える。
class AddPublishedAtToPosts < ActiveRecord::Migration[8.1]
  def up
    add_column :posts, :published_at, :datetime
    add_index :posts, :published_at

    # これまでの記事はすべて公開されていたので、作成日時を公開日時として入れておく
    execute "UPDATE posts SET published_at = created_at"
  end

  def down
    remove_column :posts, :published_at
  end
end
