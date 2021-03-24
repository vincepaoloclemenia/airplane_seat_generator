class AirplaneSeatGenerator
  AISLE_TYPE = :aisle
  WINDOW_TYPE = :window
  CENTER_TYPE = :center

  attr_reader :seating_arrangements, :passengers_count, :generated_seats
  def initialize(seating_arrangements, passengers_count)
    @seating_arrangements, @passengers_count = seating_arrangements, passengers_count
    @generated_seats = []
    has_enough_seats? or raise 'Passengers are in the wrong airplane. Some cannot be seated'
    arrange_seats_per_section
  end
  
  def display_seating_arrangments
    generated_seats.map do |section|
      section.display_section_seats
    end
  end

  def seating_arrangements_size
    seating_arrangements.size
  end

  def seat_the_passengers!
    passenger = 1
    current_seat_section = 0
    current_seat_type = AISLE_TYPE
    no_seat_occurence = 0
    seat_section_count = seating_arrangements_size - 1

    loop do
      seat_section = generated_seats[current_seat_section]

      if seat_section.has_seats_available_for?(current_seat_type)
        no_seat_occurence = 0
        passenger = seat_section.please_sit_down!(passenger, current_seat_type, passengers_count)
      else
        no_seat_occurence += 1
      end

      if passenger > passengers_count
        generated_seats.each(&:arrange_passenger_seats!)
        break
      end

      current_seat_section = if current_seat_section == seat_section_count
        0
      else
        current_seat_section + 1
      end

      if no_seat_occurence > seat_section_count
        current_seat_section = 0
        current_seat_type = case current_seat_type
                            when AISLE_TYPE
                              WINDOW_TYPE
                            when WINDOW_TYPE
                              CENTER_TYPE
                            else
                              break
                            end
      end
    end
  end

  private

  def total_capacity
    @total_capacity ||= seating_arrangements.map{ |r, c| r * c }.sum
  end

  def has_enough_seats?
    total_capacity >= passengers_count
  end

  def arrange_seats_per_section
    seating_arrangements.each_with_index do |(col, row), index|
      next if col.nil? || row.nil? || col.zero? || row.zero?
      
      generated_seats.push(
        SeatSection.new(
          row: row, 
          col: col, 
          window_position: index.zero? ? :left : index + 1 == seating_arrangements_size ? :right : nil
        )
      )
    end
  end

  class SeatSection

    attr_accessor :row, :col, :window_position
    attr_reader :seat_count_by_categories, :current_seat_section_type, :seat_count_per_category, :seats_per_row
    
    def initialize(row:, col:, window_position:)
      @row, @col, @window_position = row, col, window_position
      @current_seat_section_type = AISLE_TYPE
      @seat_count_by_categories = {
        AISLE_TYPE => [],
        WINDOW_TYPE => [],
        CENTER_TYPE => []
      }

      aisle_seats = has_window_seat? ? row : row * 2
      @center_seat_count_per_row = col - 2
      @seat_count_per_category = {
        AISLE_TYPE => aisle_seats,
        WINDOW_TYPE => has_window_seat? ? row : 0,
        CENTER_TYPE => @center_seat_count_per_row * row
      }

      @seats_per_row = {
        AISLE_TYPE => has_window_seat? ? 1 : 2,
        WINDOW_TYPE => 1,
        CENTER_TYPE => @center_seat_count_per_row
      }
    end

    def has_seats_available_for?(seat_type)
      seat_count_by_categories[seat_type].size < seat_count_per_category[seat_type]
    end

    def please_sit_down!(passenger, seat_type, passengers_count)
      passenger.nil? and raise "Passenger is missing!"
      seats_count_by_category = seat_count_per_category[seat_type]
      passengers = seat_count_by_categories[seat_type]

      seats_per_row[seat_type].times do
        passengers.push(passenger)
        passenger += 1
        break if passenger > passengers_count || passengers.size == seats_count_by_category
      end

      return passenger
    end

    def has_window_seat?
      !!window_position
    end

    def arrange_passenger_seats!
      sequence_of_arranging_seat = if window_position
        if window_position == :left
          [
            WINDOW_TYPE,
            CENTER_TYPE,
            AISLE_TYPE
          ]
        else
          [
            AISLE_TYPE,
            CENTER_TYPE,
            WINDOW_TYPE
          ]
        end
      else
        [CENTER_TYPE, AISLE_TYPE]
      end

      array_of_seats = Array.new.tap do |arr|
        row.times do
          arr.push []
        end
      end

      @array_of_seats ||= sequence_of_arranging_seat.each_with_object(array_of_seats) do |seat_type, arr|
        row_counter = 0
        
        center_type_row_builder = -> (index) {
          @center_seat_count_per_row.times do
            arr[index].push seat_count_by_categories[seat_type][row_counter]
            row_counter += 1
          end
        }

        if seat_type == CENTER_TYPE
          row.times do |n|
            center_type_row_builder.call n
          end
        else
          if window_position
            row.times do |n|
              arr[n].push seat_count_by_categories[seat_type][n]
            end
          else
            row.times do |n|
              arr[n].unshift(seat_count_by_categories[seat_type][row_counter])
              arr[n].push(seat_count_by_categories[seat_type][row_counter + 1])
              row_counter += 2
            end
          end
        end
      end
    end

    def display_section_seats
      @array_of_seats
    end
  end
end
