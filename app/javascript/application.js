// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
// import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
// import "map"
// import "chart"

$(document).ready(function () {
    initSelect2();

    $('#myModal').on('shown.bs.modal', function () {
        initSelect2InModal();
    });

    document.addEventListener('modalContentLoaded', function() {
        setTimeout(() => {
            initSelect2InModal();
        }, 100);
    });
});

function initSelect2() {
    $('.select2').not('.modal .select2').select2({
        language: 'fr',
        width: '100%',
        placeholder: 'Rechercher...',
        allowClear: true
    });
}

function initSelect2InModal() {
    $('.modal .select2').select2({
        language: 'fr',
        width: '100%',
        placeholder: 'Rechercher...',
        allowClear: true,
        dropdownParent: $('#myModal')
    });
}