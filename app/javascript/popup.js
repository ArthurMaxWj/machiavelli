// Toastify is linked in 'application.html.erb'

export default function popup(msg, kind) {
    console.log("popup:", msg)
    Toastify({
        text: msg,
        duration: 20000,
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
