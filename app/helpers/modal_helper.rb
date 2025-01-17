# frozen_string_literal: true

module ModalHelper
    def modal_header(title)
        raw("<div class='modal-header' style='width: 100%;'>
            <div class='modal-title'>#{title}</div>
            <div style='padding: 0.33rem;'>
                <button type='button' style=' float: right' class='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
            </div>
        </div>")
    end

    def open_modal(url, button_text, class_names = nil)
        url_idfied = url.sub(%r{^/}, '').tr('/', '_').to_s
        content = "<button class='btn #{class_names}' id='#{url_idfied}'>#{button_text}</button>"
        content += "<script type='module'>"
        content += "$(document).ready(function() {
        const button = document.getElementById('#{url_idfied}');
        button.addEventListener('click', () => {
            #{js_call(url)}
        });});"
        content += '</script>'
        raw(content)
    end

    def js_call(url)
        # log = "console.log(data);" if Rails.env.development?
        log = ''
        "fetch('#{url}').then(response => response.text()).then(data => {
         #{log}
         $('.modal-content').html(data);
     }).then(() => {
         document.getElementById('autoLaunchButton').click();
         document.dispatchEvent(new Event('modalContentLoaded'));
     });"
    end

    def open_modal_icon(url, icon_type, style = '', class_names = nil)
        url_idfied = "#{url.sub(%r{^/}, '').tr('/', '_')}-icon"
        content = "<i class='material-icons clickable #{class_names}' id='#{url_idfied}' style='#{style}'>#{icon_type}</i>"
        content += "<script type='module'>"
        content += "$(document).ready(function() {
        const icon = document.getElementById('#{url_idfied}');
        icon.addEventListener('click', () => {
            #{js_call(url)}
        });});"
        content += '</script>'
        raw(content)
    end
end
