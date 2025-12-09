# WebGPU Interactive Ray Marching Scene Editor 🚀

A powerful, interactive 3D scene editor built with **WebGPU** and **WGSL**. Edit shaders and scene objects in real-time with a professional UI panel.

## 🎯 Live Demo

**[View Live Demo](https://YOUR_USERNAME.github.io/YOUR_REPO_NAME/)** ← Deploy to GitHub Pages

## ✨ Features

- **Real-time Shader Editing** – Write and compile WGSL shaders on the fly
- **Interactive Scene Panel** – Edit sphere, torus, and ground plane properties with sliders
- **Color Picker** – Change material colors instantly
- **Ray Marching Rendering** – High-performance 3D rendering with WebGPU
- **Smooth Animations** – Auto-orbiting camera with smooth transitions
- **Multiple Objects** – Smooth-blend sphere and torus with checkerboard ground plane

## 🛠️ Tech Stack

- **WebGPU** – Modern GPU API
- **WGSL** – WebGPU Shading Language
- **JavaScript (ES6)** – Interactive controls
- **HTML5 & CSS3** – Professional UI
- **Ray Marching** – Advanced rendering technique

## 🚀 Local Development

### Prerequisites
- Modern browser with WebGPU support (Chrome, Edge, Opera)
- Python 3.x

### Setup

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME

# Start local server
python -m http.server

# Open in browser
# Navigate to http://localhost:8000
```

### File Structure

```
.
├── index.html          # Main HTML interface
├── main.js             # WebGPU setup & render loop
├── style.css           # UI styling
└── shaders/
    ├── RyuShader.wgsl  # Interactive ray marching shader
    ├── mouse.wgsl      # Mouse interaction shader
    └── ...other shaders
```

## 📝 Usage

1. **Edit Shaders** – Paste or write WGSL code in the editor panel
2. **Compile** – Press `Ctrl+Enter` or click "Compile"
3. **Edit Scene** – Use sliders in the scene panel to adjust:
   - Object positions (X, Y, Z)
   - Radius/size
   - Colors
4. **Watch Changes** – See real-time updates in the viewport

## 🎨 Scene Editor Features

- **Sphere Controls** – Position, radius, color
- **Torus Controls** – Position, major radius, thickness, color
- **Ground Plane** – Checkerboard pattern with lighting

## 📚 Resources

- [Inigo Quilez - Articles on SDFs](https://iquilezles.org/articles/)
- [WGSL Specification](https://www.w3.org/TR/WGSL/)
- [WebGPU Fundamentals](https://webgpufundamentals.org/)

## 📄 License

MIT License – Feel free to use this project for learning and development.

---

**Made with ❤️ for ESILV A5 AICG**
