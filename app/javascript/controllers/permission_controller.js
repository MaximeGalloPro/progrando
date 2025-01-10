import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    toggle(event) {
        event.preventDefault()

        const badge = event.currentTarget

        fetch(this.element.dataset.permissionUrl, {
            method: 'PATCH',
            headers: {
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
                'Accept': 'application/json',
                'Content-Type': 'application/json'
            },
            credentials: 'same-origin'
        })
            .then(response => response.json())
            .then(data => {
                if (data.authorized) {
                    badge.classList.remove('bg-danger')
                    badge.classList.add('bg-success')
                    badge.textContent = 'Autorisé'
                } else {
                    badge.classList.remove('bg-success')
                    badge.classList.add('bg-danger')
                    badge.textContent = 'Non autorisé'
                }
            })
            .catch(error => {
                console.error('Error:', error)
                alert('Une erreur est survenue lors de la mise à jour de la permission')
            })
    }
}