# 「アプリ側のバリデーション」だけで守っていたルールを、DB にも制約として持たせる。
# バリデーションは Rails を通さない書き込み（コンソールでの直接操作や、同時に2つのリクエストが来た場合）では守られないため。
#
# 既存データが制約に違反していると制約を追加できないので、先にデータを整えてから追加する。
class AddConstraintsToPostsAndTags < ActiveRecord::Migration[8.1]
  def up
    # 1. 名前が空のタグは削除する（記事との紐付けも消す）
    execute <<~SQL
      DELETE tag_maps FROM tag_maps
        JOIN tags ON tags.id = tag_maps.tag_id
       WHERE tags.tag_name IS NULL OR TRIM(tags.tag_name) = ''
    SQL
    execute "DELETE FROM tags WHERE tag_name IS NULL OR TRIM(tag_name) = ''"

    # 2. 同じ名前のタグを1つにまとめる
    #    （照合順序が utf8mb4_unicode_ci なので、"Ruby" と "ruby" も同じ名前として扱われる）
    select_rows(<<~SQL).each do |keep_id, all_ids|
      SELECT MIN(id), GROUP_CONCAT(id) FROM tags GROUP BY tag_name HAVING COUNT(*) > 1
    SQL
      duplicate_ids = all_ids.split(",").map(&:to_i) - [ keep_id.to_i ]
      execute "UPDATE tag_maps SET tag_id = #{keep_id.to_i} WHERE tag_id IN (#{duplicate_ids.join(',')})"
      execute "DELETE FROM tags WHERE id IN (#{duplicate_ids.join(',')})"
    end

    # 3. 同じ記事に同じタグが2回付いている紐付けを1つにする
    execute <<~SQL
      DELETE newer FROM tag_maps newer
        JOIN tag_maps older
          ON older.post_id = newer.post_id AND older.tag_id = newer.tag_id AND older.id < newer.id
    SQL

    # 4. タイトル・本文が NULL の記事を埋める
    execute "UPDATE posts SET title = '(無題)' WHERE title IS NULL"
    execute "UPDATE posts SET content = '' WHERE content IS NULL"

    # ここから制約の追加
    change_column_null :posts, :title, false
    change_column_null :posts, :content, false
    change_column_null :tags, :tag_name, false
    add_index :tags, :tag_name, unique: true
    add_index :tag_maps, [ :post_id, :tag_id ], unique: true
    # post_id だけのインデックスは、上の複合インデックス（先頭が post_id）で代わりが利くので消す
    remove_index :tag_maps, :post_id
  end

  def down
    add_index :tag_maps, :post_id
    remove_index :tag_maps, [ :post_id, :tag_id ]
    remove_index :tags, :tag_name
    change_column_null :tags, :tag_name, true
    change_column_null :posts, :content, true
    change_column_null :posts, :title, true
  end
end
