import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

// ---- 1) Your data: array of segments, each = [[x,y,z], [x,y,z]]
const segments = await fetch("list.json").then((r) => r.json());

// Flatten segments into positions: [x1,y1,z1, x2,y2,z2, x1,y1,z1, x2,y2,z2, ...]
const positions = new Float32Array(segments.length * 2 * 3);
let i = 0;
for (const [a, b] of segments) {
    positions[i++] = a[0];
    positions[i++] = a[1];
    positions[i++] = a[2];
    positions[i++] = b[0];
    positions[i++] = b[1];
    positions[i++] = b[2];
}

// ---- 2) Scene / camera / renderer
const scene = new THREE.Scene();
scene.add(new THREE.AxesHelper(1.5));

const camera = new THREE.PerspectiveCamera(
    60,
    window.innerWidth / window.innerHeight,
    0.01,
    1000,
);
camera.position.set(3, 3, 3);

const renderer = new THREE.WebGLRenderer({ antialias: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
document.body.appendChild(renderer.domElement);

// ---- 3) Controls
const controls = new OrbitControls(camera, renderer.domElement);
controls.target.set(0, 0, 0);
controls.update();

// ---- 4) Geometry + material + LineSegments
const geometry = new THREE.BufferGeometry();
geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3)); // setAttribute is how you feed vertex buffers :contentReference[oaicite:1]{index=1}

const material = new THREE.LineBasicMaterial(); // default color is fine
const lines = new THREE.LineSegments(geometry, material);
scene.add(lines);

// Optional: auto-frame camera to your data
geometry.computeBoundingSphere();
if (geometry.boundingSphere) {
    const r = geometry.boundingSphere.radius;
    controls.target.copy(geometry.boundingSphere.center);
    camera.position.copy(controls.target).add(
        new THREE.Vector3(r * 2, r * 1.5, r * 2),
    );
    camera.near = r / 100;
    camera.far = r * 100;
    camera.updateProjectionMatrix();
    controls.update();
}

// ---- 5) Resize + render loop
window.addEventListener("resize", () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
});

function animate() {
    requestAnimationFrame(animate);
    renderer.render(scene, camera);
}
animate();
