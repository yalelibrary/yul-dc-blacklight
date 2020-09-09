# frozen_string_literal: true

def ensure_click_link(link_name, page)
  counter = 0
  begin
    while (counter < 10) && page.find_link(link_name)
      click_link(link_name)
      counter += 1
    end
  rescue Capybara::ElementNotFound => e
    return if counter > 0
    raise e
  rescue => e
    raise e
  end
end
