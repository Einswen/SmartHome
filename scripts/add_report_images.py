from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt
from docx.oxml.ns import qn


ROOT = Path(r"C:\Users\18712\Desktop\SmartHome")
MEDIA = ROOT / "entry" / "src" / "main" / "resources" / "base" / "media"
SRC = ROOT / "专业实习报告-SmartHome智能家居控制系统-去雷同版.docx"
OUT = ROOT / "专业实习报告-SmartHome智能家居控制系统-图文版.docx"
WORK = ROOT / "report_assets"


def font(size=28, bold=False):
    candidates = [
        r"C:\Windows\Fonts\msyhbd.ttc" if bold else r"C:\Windows\Fonts\msyh.ttc",
        r"C:\Windows\Fonts\simhei.ttf",
        r"C:\Windows\Fonts\simsun.ttc",
    ]
    for path in candidates:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def fit_image(src, box):
    img = Image.open(src).convert("RGB")
    img.thumbnail(box, Image.Resampling.LANCZOS)
    canvas = Image.new("RGB", box, "white")
    x = (box[0] - img.width) // 2
    y = (box[1] - img.height) // 2
    canvas.paste(img, (x, y))
    return canvas


def make_compare_grid(name, items, title):
    cell_w, cell_h = 520, 360
    pad, title_h, cap_h = 28, 70, 42
    cols = 2
    rows = (len(items) + 1) // 2
    out = Image.new("RGB", (cols * cell_w + pad * 3, title_h + rows * (cell_h + cap_h) + pad * (rows + 1)), "#F6F7F9")
    draw = ImageDraw.Draw(out)
    draw.text((pad, 20), title, fill="#111827", font=font(30, True))
    for idx, (caption, path) in enumerate(items):
        row = idx // cols
        col = idx % cols
        x = pad + col * (cell_w + pad)
        y = title_h + pad + row * (cell_h + cap_h + pad)
        draw.rounded_rectangle((x - 2, y - 2, x + cell_w + 2, y + cell_h + cap_h + 2), radius=16, fill="#FFFFFF", outline="#D6DAE0")
        img = fit_image(path, (cell_w, cell_h))
        out.paste(img, (x, y))
        draw.text((x + 12, y + cell_h + 8), caption, fill="#374151", font=font(20, False))
    out_path = WORK / name
    out.save(out_path, quality=92)
    return out_path


def make_device_panel():
    items = [
        ("客厅空调", MEDIA / "device_living_air.png"),
        ("客厅照明", MEDIA / "device_living_light.png"),
        ("空气净化器", MEDIA / "device_living_purifier.png"),
        ("扫地机器人", MEDIA / "device_living_robot.png"),
        ("卧室门锁", MEDIA / "device_bedroom_door.png"),
        ("手势传感器", MEDIA / "device_gesture_sensor.png"),
    ]
    cell_w, cell_h = 210, 190
    pad, title_h = 24, 68
    out = Image.new("RGB", (3 * cell_w + 4 * pad, title_h + 2 * (cell_h + 34) + 3 * pad), "#F6F7F9")
    draw = ImageDraw.Draw(out)
    draw.text((pad, 18), "设备资源与控制对象", fill="#111827", font=font(30, True))
    for idx, (caption, path) in enumerate(items):
        row = idx // 3
        col = idx % 3
        x = pad + col * (cell_w + pad)
        y = title_h + pad + row * (cell_h + 34 + pad)
        draw.rounded_rectangle((x, y, x + cell_w, y + cell_h + 34), radius=16, fill="#FFFFFF", outline="#D6DAE0")
        img = fit_image(path, (cell_w - 30, cell_h - 28))
        out.paste(img, (x + 15, y + 10))
        tw = draw.textlength(caption, font=font(19))
        draw.text((x + (cell_w - tw) / 2, y + cell_h + 4), caption, fill="#374151", font=font(19))
    out_path = WORK / "device_panel.png"
    out.save(out_path, quality=92)
    return out_path


def make_flow():
    out = Image.new("RGB", (1080, 360), "#F6F7F9")
    draw = ImageDraw.Draw(out)
    draw.text((32, 24), "智能助手指令解析流程", fill="#111827", font=font(32, True))
    boxes = [
        ("输入自然语言", "例如：每天22:30关闭客厅灯"),
        ("识别触发条件", "时间、离家、回家、每周"),
        ("生成设备动作", "pointId + command + value"),
        ("保存自动化脚本", "展示、展开、启用/停用"),
    ]
    x, y = 36, 112
    bw, bh, gap = 220, 132, 40
    for idx, (head, body) in enumerate(boxes):
        bx = x + idx * (bw + gap)
        draw.rounded_rectangle((bx, y, bx + bw, y + bh), radius=18, fill="#FFFFFF", outline="#CBD5E1", width=2)
        draw.text((bx + 20, y + 24), head, fill="#111827", font=font(23, True))
        draw.text((bx + 20, y + 70), body, fill="#4B5563", font=font(18))
        if idx < len(boxes) - 1:
            ax1 = bx + bw + 8
            ay = y + bh // 2
            ax2 = bx + bw + gap - 8
            draw.line((ax1, ay, ax2, ay), fill="#64748B", width=4)
            draw.polygon([(ax2, ay), (ax2 - 12, ay - 8), (ax2 - 12, ay + 8)], fill="#64748B")
    out_path = WORK / "assistant_flow.png"
    out.save(out_path, quality=92)
    return out_path


def set_caption(paragraph):
    paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    paragraph.paragraph_format.space_before = Pt(2)
    paragraph.paragraph_format.space_after = Pt(8)
    for run in paragraph.runs:
        run.font.name = "宋体"
        run._element.rPr.rFonts.set(qn("w:eastAsia"), "宋体")
        run.font.size = Pt(10.5)


def add_image_after(paragraph, image_path, caption, width):
    image_p = paragraph.insert_paragraph_before()
    image_p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    image_p.add_run().add_picture(str(image_path), width=Inches(width))
    cap_p = paragraph.insert_paragraph_before(caption)
    set_caption(cap_p)


def insert_before_contains(doc, marker, image_path, caption, width):
    for paragraph in doc.paragraphs:
        if marker in paragraph.text:
            add_image_after(paragraph, image_path, caption, width)
            return True
    return False


def main():
    WORK.mkdir(exist_ok=True)
    living_compare = make_compare_grid(
        "living_compare.png",
        [
            ("客厅 日间关灯", MEDIA / "room_living_day_lightoff.png"),
            ("客厅 日间开灯", MEDIA / "room_living_day_lighton.png"),
            ("客厅 夜间关灯", MEDIA / "room_living_night_lightoff.png"),
            ("客厅 夜间开灯", MEDIA / "room_living_night_lighton.png"),
        ],
        "客厅日夜与灯光状态对比",
    )
    bedroom_compare = make_compare_grid(
        "bedroom_compare.png",
        [
            ("卧室 日间关灯", MEDIA / "room_bed_day_lightoff.png"),
            ("卧室 日间开灯", MEDIA / "room_bed_day_lighton.png"),
            ("卧室 夜间关灯", MEDIA / "room_bed_night_lightoff.png"),
            ("卧室 夜间开灯", MEDIA / "room_bed_night_lighton.png"),
        ],
        "卧室日夜与灯光状态对比",
    )
    device_panel = make_device_panel()
    assistant_flow = make_flow()

    doc = Document(SRC)
    insert_before_contains(doc, "用例层面，用户进入应用后首先浏览首页中控视图", living_compare, "图4-4 客厅日夜与灯光状态对比", 5.9)
    insert_before_contains(doc, "系统采用单 entry 模块组织", bedroom_compare, "图4-5 卧室日夜与灯光状态对比", 5.9)
    insert_before_contains(doc, "在数据模型设计上，Index.ets 中定义了", device_panel, "图4-6 SmartHome 设备资源与控制对象", 5.6)
    insert_before_contains(doc, "第三，智能助手采用本地规则优先的策略", assistant_flow, "图4-7 智能助手指令解析流程", 5.9)
    doc.save(OUT)
    print(OUT)
    print(f"images={len(doc.inline_shapes)} paragraphs={len(doc.paragraphs)} tables={len(doc.tables)}")


if __name__ == "__main__":
    main()
