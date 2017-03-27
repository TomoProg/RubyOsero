class RubyOsero
  BLANK = "・" # 置き石無し
  BLACK = "○ " # 黒
  WHITE = "● " # 白
  WALL  = "■ " # 終端
  MAX_ROW = 10 # 行
  MAX_COL = 10 # 列

  @@field = nil # フィールド
  @@turn = nil  # ターン

  def run()
    # 初期化
    @@turn = BLACK
    make_field()
    print_field()

    while true

      puts "<< #{@@turn}のターン >>"

      # 石を置ける場所をチェック
      can_put_pos_list = search_can_put_pos(@@turn)
      if can_put_pos_list.empty?
        puts "置ける場所がないため、#{@@turn}のターンは飛ばされます。"
        change_turn()
        next
      end

      # 石を置く座標を入力
      #puts "置ける場所 ---> #{can_put_pos_list}"
      print "置き場所を行,列で指定してください。ex.)1,2 ---> "
      put_pos = gets

      # 入力文字チェック
      if !check_input(put_pos)
        next
      end

      # 置き場所チェック
      put_pos = put_pos.chomp().split(",")
      row = Integer(put_pos[0].strip)
      col = Integer(put_pos[1].strip)
      if !can_put_pos_list.include?([row, col])
        puts "指定された場所に置くことはできません。"
        next
      end

      # 反転処理
      reverse(row, col)

      # 盤面表示
      print_field()

      # 終了判定
      if finish?()
        break
      end

      # ターン交代
      change_turn()
    end

    # 結果表示
    print_result()
  end

  def make_field()
    @@field = []
    MAX_ROW.times do
      row = []
      MAX_COL.times do
        row << BLANK
      end
      @@field << row
    end

    0.upto(MAX_COL - 1) do |i|
      @@field[0][i] = WALL
      @@field[MAX_ROW - 1][i] = WALL
    end
    0.upto(MAX_ROW - 1) do |i|
      @@field[i][0] = WALL
      @@field[i][MAX_COL - 1] = WALL
    end

    @@field[4][4] = WHITE
    @@field[5][5] = WHITE
    @@field[4][5] = BLACK
    @@field[5][4] = BLACK
  end

  def print_field
    print "  "
    0.upto(MAX_COL - 1) do |i|
      print i.to_s + " "
    end
    print "\n"

    for i in 0..MAX_ROW - 1
      print i.to_s + " "
      row = @@field[i]
      row.each do |stone|
        print stone
      end
      print "\n"
    end
  end

  def check_input(input)
    input = input.chomp.split(",")
    if input.length != 2
      puts "石を置く場所を正しく指定してください。"
      return false
    end

    if !integer_string?(input[0].strip) || !integer_string?(input[1].strip)
      puts "石を置く場所は数値で指定してください"
      return false
    end

    return true
  end

  def search_can_put_pos(turn)
    enemy = get_enemy(turn)
    can_put_pos_list = []
    directions = [[-1,0], [-1,1], [0,1], [1,1], [1,0], [1,-1], [0,-1], [-1,-1]]

    for row_num in 0..(MAX_ROW - 1)
      for col_num in 0..(MAX_COL - 1)
        if @@field[row_num][col_num] != BLANK
          next
        end

        directions.each do |direction|
          can_put_flag = false
          search_row = row_num + direction[0]
          search_col = col_num + direction[1]
          if @@field[search_row][search_col] != enemy
            next
          end

          while true
            search_row += direction[0]
            search_col += direction[1]
            if @@field[search_row][search_col] != enemy && @@field[search_row][search_col] != turn
              break
            elsif @@field[search_row][search_col] == enemy
              next
            else
              can_put_pos_list << [row_num, col_num]
              can_put_flag = true
              break
            end
          end

          if can_put_flag
            break
          end
        end
      end
    end

    return can_put_pos_list
  end

  def reverse(put_row, put_col)
    enemy = get_enemy(@@turn)
    directions = [[-1,0], [-1,1], [0,1], [1,1], [1,0], [1,-1], [0,-1], [-1,-1]]

    @@field[put_row][put_col] = @@turn
    directions.each do |direction|
      reverse_pos = []
      reverse_row = put_row + direction[0]
      reverse_col = put_col + direction[1]
      if @@field[reverse_row][reverse_col] != enemy
        next
      end

      reverse_flag = false
      reverse_pos << [reverse_row, reverse_col]
      while true
        reverse_row += direction[0]
        reverse_col += direction[1]
        if @@field[reverse_row][reverse_col] == enemy
          reverse_pos << [reverse_row, reverse_col]
        elsif @@field[reverse_row][reverse_col] == @@turn
          reverse_flag = true
          break
        else
          break
        end
      end

      if reverse_flag
        reverse_pos.each do |pos|
          @@field[pos[0]][pos[1]] = @@turn
        end
      end
    end
  end

  def finish?()
    can_put_white_list = search_can_put_pos(WHITE)
    can_put_black_list = search_can_put_pos(BLACK)
    if can_put_white_list.empty? && can_put_black_list.empty?
      return true
    end
    return false
  end

  def print_result()
    black_num = 0
    white_num = 0
    @@field.each do |row|
      row.each do |stone|
        if stone == BLACK
          black_num += 1
        elsif stone == WHITE
          white_num += 1
        end
      end
    end

    puts "<< 結果 >>"
    puts "#{BLACK}:#{black_num} #{WHITE}:#{white_num}"
    if black_num > white_num
      puts "#{BLACK}の勝利です。"
    elsif black_num < white_num
      puts "#{WHITE}の勝利です。"
    else
      puts "引き分けです。"
    end
  end

  def change_turn()
    if @@turn == BLACK
      @@turn = WHITE
    else
      @@turn = BLACK
    end
  end

  def get_enemy(turn)
    if turn == BLACK
      return WHITE
    else
      return BLACK
    end
  end

  def integer_string?(str)
    begin
      Integer(str)
      return true
    rescue
      return false
    end
  end

end

game = RubyOsero.new
game.run()
