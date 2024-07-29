// Toastify is imported in 'application.html.erb' and config/importmap.rb under "shared"

export default function popup(msg, kind) {
    console.log("popup:", msg)
    Toastify({
        text: msg,
        duration: 2500,
        newWindow: true,
        close: true,
        gravity: "top", 
        position: "center",
        stopOnFocus: true,
        className: kind,
        style: {
            background: "linear-gradient(to bottom, #eee, #666)",
        }
    }).showToast()
}
