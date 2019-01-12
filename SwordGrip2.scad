//!OpenSCAD

//*************** ПЕРЕМЕННЫЕ ***************************************************
//Все размеры в см.
TOLERANCE = 0.05; // TODO: Спросить Диму о допуске на усадку.
GRIP_LENGTH = 20;
GRIP_WIDTH = 3.5;
GRIP_HEIGHT = 2.5;
WALL_WIDTH = 0.3;
BLADE_THICKNESS = 0.9 + 0.2; //Значение + запас TODO: выразить запас в TOLERANCE
BLADE_WIDTH = 2 + 0.3; //Значение + запас TODO: выразить запас в TOLERANCE
HOLDER_WIDTH = BLADE_WIDTH;
HOLDER_LENGTH = GRIP_LENGTH/2;

BUTTON_LENGTH = 0.5;
BUTTON_WIDTH = 0.8;
BUTTON_HEIGHT = 0.7;
BUTTON_WINDOW_LENGTH = WALL_WIDTH;
BUTTON_WINDOW_WIDTH = 0.3;
BUTTON_WINDOW_INTEND = 0.08;
BUTTON_WINDOW_HEIGHT = BUTTON_HEIGHT - BUTTON_WINDOW_INTEND * 2;
BUTTON_REST_LENGTH = 0.5;
BUTTON_REST_WIDTH = 0.3;
BUTTON_REST_HEIGHT = BUTTON_HEIGHT;
BUTTON_SHELF_LENGTH = BUTTON_WINDOW_LENGTH + BUTTON_LENGTH + BUTTON_REST_LENGTH;
LEG_EXTRA_SPACE = 0.1;

// Нижняя крышка с кнопкой.
CAP_LENGTH = BUTTON_SHELF_LENGTH;
CAP_HEAD_WIDTH = GRIP_WIDTH;
CAP_BODY_WIDTH = CAP_HEAD_WIDTH - (WALL_WIDTH + TOLERANCE) * 2;
CAP_HEAD_HEIGHT = GRIP_HEIGHT;
CAP_BODY_HEIGHT = CAP_HEAD_HEIGHT - (WALL_WIDTH + TOLERANCE) * 2;
CAP_HEAD = BUTTON_WINDOW_LENGTH;
CAP_BODY = CAP_LENGTH - CAP_HEAD;
CAP_SCREW_X = CAP_HEAD + CAP_BODY/2;

BATTERY_BLOCK_LENGTH = GRIP_LENGTH - HOLDER_LENGTH;
BATTERY_BLOCK_WIDTH = GRIP_WIDTH - 2 * WALL_WIDTH;
BATTERY_BLOCK_HEIGHT = GRIP_HEIGHT - 2 * WALL_WIDTH;
BATTERY_BLOCK_INTEND = HOLDER_LENGTH;
NUT_D = 1.13; // Внешний диаметр гайки. Должно подходить для М5
NUT_D_M3 = 0.7; // Диаметр гайки М3
SCREW_D = 0.6; // Диаметр резьбы болта. Идеально для М5
SCREW_D_M3 = 0.32; // Диаметр резьбы болта М3
SCREW_POINT_M3_X = GRIP_LENGTH - CAP_BODY/2 + TOLERANCE;
SCREW_POINT_M3_Y = BUTTON_WIDTH/2 + LEG_EXTRA_SPACE + WALL_WIDTH;
SCREW_INTEND = 2;
SCREW_POINTS = [(HOLDER_LENGTH - SCREW_INTEND)/3 + SCREW_INTEND,
                2*(HOLDER_LENGTH - SCREW_INTEND)/3 + SCREW_INTEND];

$fn=180;


//********************* MAIN ***************************************************

// translate([0, GRIP_WIDTH * 1.5, 0])
// 	gripBase();
	
// translate([0, -GRIP_WIDTH * 1.5, 0])
// 	gripBase();
	
// capWithButton();

translate([-GRIP_LENGTH - WALL_WIDTH - TOLERANCE, 0, 0])
	gripBase();

rotate([180, 0, 0])
	translate([-GRIP_LENGTH - WALL_WIDTH - TOLERANCE, 0, 0])
		gripBase();
	
rotate([0, 0, 180])
	capWithButton();

//*************** МОДУЛИ ***************************************************
module screwHoles(H, holeH, nutD, screwD) {
    union() {
        cylinder (r=nutD/2, h=H - holeH, $fn=6);
        translate([0, 0, H - holeH])
            cylinder (r=screwD/2, h=holeH);
    }
}

module circaled(h, t, w) {
	minAx = min(t, w);
	maxAx = max(t, w);
	hull() {
		translate([0, (maxAx-minAx)/2, 0]) 
			cylinder(r=minAx/2, h=h);
		translate([0, -(maxAx-minAx)/2, 0]) 
			cylinder(r=minAx/2, h=h);
	}
}

module gripWall (L, W, H) {
        rotate([0, 90 , 0])
            circaled(L, W, H);
}

module gripWallHalf(L, W, H) {
    difference () {
        gripWall(L, W, H);
        translate ([0, -W/2, 0])
			cube ([L, W, H/2]);
    }
}

module batteryBlock(batBlL, batBlW, batBlH, batBlIntend) {
    translate ([batBlIntend, 0, 0])
            rotate([0, 90 , 0])
                circaled(batBlL,
                    batBlW,
                    batBlH);
}

module buttonHole(butL, butW, butH,
	butWinL, butWinW, butWinH, butWinInt,
	butRestL, butRestW, butRestH, legExtraSpace) {
	
	// Координаты от середины кнопки. TOLERANCE используется для более удобного предпросмотра в редакторе, 
	// и не влияет на саму модель
	legWidth = (butW - butRestW)/2;
	union() {
		// Вырезы для ножек кнопки. 
		// Между ними сформируется стопор для тела кнопки.
		for(legsHoleY = [butRestW/2, -legWidth - butRestW/2 - legExtraSpace]) {
			translate([butL + butWinL, legsHoleY, 0]) // по х - тело кнопки + окошко
				cube([butRestL + TOLERANCE, legWidth + legExtraSpace, butRestH]); // Про TOLERANCE см. выше
		}
		// "Тело" кнопки
		translate([butWinL, -butW/2, 0]) // по х - окошко
			cube([butL, butW, butH]);
		// "Окошко" для нажимной части кнопки. Про TOLERANCE см. выше
		translate([-TOLERANCE, (butW - butWinW)/2 - butW/2, butWinInt]) // по х - 0,1
			cube([butWinL + TOLERANCE, butWinW, butWinH]);
	}
}

module gripBase() {
    difference() {
		gripWallHalf(GRIP_LENGTH, GRIP_WIDTH, GRIP_HEIGHT);

		// Отверстия для соединения половинок
    for (screwPoint = SCREW_POINTS) {
        translate([screwPoint, 0, -GRIP_HEIGHT/2])
            screwHoles(GRIP_HEIGHT/2,
                WALL_WIDTH + BLADE_THICKNESS/2, NUT_D, SCREW_D);
    }
	
	// Отверстие для соединения в задней части
	translate([SCREW_POINT_M3_X, SCREW_POINT_M3_Y, -GRIP_HEIGHT/2])
		screwHoles(GRIP_HEIGHT/2, GRIP_HEIGHT/2, NUT_D_M3, SCREW_D_M3);
	translate([SCREW_POINT_M3_X, -SCREW_POINT_M3_Y, -GRIP_HEIGHT/2])
		screwHoles(GRIP_HEIGHT/2, GRIP_HEIGHT/2 - 0.15, NUT_D_M3, SCREW_D_M3);

		// Держатель лезвия
    translate([0, -BLADE_WIDTH/2, -BLADE_THICKNESS/2])
        cube ([HOLDER_LENGTH, BLADE_WIDTH, BLADE_THICKNESS/2]);

	// Отсек для батареек
	batteryBlock(BATTERY_BLOCK_LENGTH, BATTERY_BLOCK_WIDTH,
		BATTERY_BLOCK_HEIGHT, BATTERY_BLOCK_INTEND);
    }
}

module capWithButton() {
	difference() {
		union() {
			gripWall(CAP_HEAD, CAP_HEAD_WIDTH, CAP_HEAD_HEIGHT);
			difference() {
				gripWall(CAP_LENGTH, CAP_BODY_WIDTH, CAP_BODY_HEIGHT);
				// Отверстие для соединения в задней части
				translate([CAP_SCREW_X, SCREW_POINT_M3_Y, -GRIP_HEIGHT/2])
					screwHoles(GRIP_HEIGHT, GRIP_HEIGHT, NUT_D_M3, SCREW_D_M3);
				translate([CAP_SCREW_X, -SCREW_POINT_M3_Y, -GRIP_HEIGHT/2])
					screwHoles(GRIP_HEIGHT, GRIP_HEIGHT, NUT_D_M3, SCREW_D_M3);
			}
		}
		translate([0, 0, CAP_BODY_HEIGHT/2 - BUTTON_HEIGHT])
			buttonHole(BUTTON_LENGTH, BUTTON_WIDTH, BUTTON_HEIGHT,
					BUTTON_WINDOW_LENGTH, BUTTON_WINDOW_WIDTH, BUTTON_WINDOW_HEIGHT,
					BUTTON_WINDOW_INTEND,
					BUTTON_REST_LENGTH, BUTTON_REST_WIDTH, BUTTON_REST_HEIGHT, 
					LEG_EXTRA_SPACE);
	}
}
