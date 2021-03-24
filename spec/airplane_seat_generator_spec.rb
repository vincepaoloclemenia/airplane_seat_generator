require 'airplane_seat_generator'
require 'pry'

describe AirplaneSeatGenerator do

  let(:seating_draft) do
    [[3,2], [4,3], [2,3], [3,4]]
  end
  
  let(:passengers_count) { 30 }
    
  let(:expected_result) do
    [
      [
        [19, 25, 1], 
        [21, 29, 7]
      ], 
      [
        [2, 26, 27, 3], 
        [8, 30, nil, 9], 
        [13, nil, nil, 14]
      ],
      [
        [4, 5], 
        [10, 11], 
        [15, 16]
      ], 
      [
        [6, 28, 20], 
        [12, nil, 22], 
        [17, nil, 23], 
        [18, nil, 24]
      ]
    ]
  end

  shared_examples 'displays the airplane seating arrangement properly' do
    it 'creates draft for seating arrangment and let passengers seat accordingly' do
      seat_generator = AirplaneSeatGenerator.new(seating_draft, passengers_count)
      seat_generator.seat_the_passengers!
      expect(seat_generator.display_seating_arrangments).to eq(expected_result)
    end
  end

  include_examples 'displays the airplane seating arrangement properly'

  context 'second sample' do
    let(:seating_draft) do
      [[3,4], [4,5], [2,3], [3,4]]
    end

    let(:expected_result) do
      [
        [
          [25, nil, 1], 
          [27, nil, 7], 
          [29, nil, 13], 
          [nil, nil, 19]
        ],
        [
          [2, nil, nil, 3], 
          [8, nil, nil, 9], 
          [14, nil, nil, 15], 
          [20, nil, nil, 21], 
          [23, nil, nil, 24]
        ],
        [
          [4, 5], 
          [10, 11], 
          [16, 17]
        ],
        [
          [6, nil, 26], 
          [12, nil, 28], 
          [18, nil, 30], 
          [22, nil, nil]
        ]
      ]
    end
    
    include_examples 'displays the airplane seating arrangement properly'
  end

  context 'third example' do
    let(:seating_draft) do
      [[4,4], [4,4], [4,4], [4,4]]
    end

    let(:passengers_count) { 64 }

    let(:expected_result) {
      [
        [
          [25, 33, 34, 1], 
          [27, 41, 42, 7], 
          [29, 49, 50, 13], 
          [31, 57, 58, 19]
        ],
        [
          [2, 35, 36, 3], 
          [8, 43, 44, 9], 
          [14, 51, 52, 15], 
          [20, 59, 60, 21]
        ],
        [
          [4, 37, 38, 5], 
          [10, 45, 46, 11], 
          [16, 53, 54, 17], 
          [22, 61, 62, 23]
        ],
        [
          [6, 39, 40, 26], 
          [12, 47, 48, 28], 
          [18, 55, 56, 30], 
          [24, 63, 64, 32]
        ]
      ]
    }
    
    include_examples 'displays the airplane seating arrangement properly'
  end
end