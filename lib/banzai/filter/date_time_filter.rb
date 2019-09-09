# frozen_string_literal: true

module Banzai
  module Filter
    class DateTimeFilter < HTML::Pipeline::Filter
      DATETIME_CLASS = 'gfm-date_time'.freeze

      def call
        doc.css('code').each do |node|
          begin
            date = Time.parse(node.content)
          rescue
            next
          end


          element = doc.document.create_element('span', class: DATETIME_CLASS, style: 'background-color: #DCDCDC; color: black')
          element.content = if current_user
                              date.in_time_zone(current_user.timezone)
                            else
                              date
                            end

          node.content = ''
          node << element
        end

        doc
      end

      private

      def current_user
        context[:current_user]
      end
    end
  end
end
