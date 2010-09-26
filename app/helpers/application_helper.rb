module ApplicationHelper
  def my_markdown(input)
    raw(BlueCloth.new(input).to_html)
  end
end
