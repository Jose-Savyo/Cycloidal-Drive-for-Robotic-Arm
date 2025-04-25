
//////////////////// Bloco da cycloid ///////////////////

$fn=200;  // Resolução para curvas
r=1.1;   // Raio aproximado dos dentes
fra=1.1;  // Fração da engrenagem associada ao NEMA17
//n=round(fra*(31/1.414)/r);  // Número de dentes
n = 17;
n2 = n-7; // Número de dentes do segundo estágio
echo("Número de Dentes do primeiro estágio:", n);
echo("Número de Dentes do degundo estágio:", n2);
r1=fra*(31/1.41)/n;  // Raio real dos dentes
h=5.5;  // Altura padrão
h1=h-2;  // Altura auxiliar



// Cria o perfil cycloidal para os dentes da engrenagem.
// 'rof' adiciona uma folga para garantir encaixe sem interferências.

module cycloid(order=100, r=1,n=10,k=1){
    R=n*r;
    angles=[ for (i = [0:order-1]) i*(360/order) ];
    coords=[ for (th=angles) [(R-r)*cos(th)+r*cos(th*(R-r)/r), (R-r)*sin(th)-r*sin(th*(R-r)/r)] ];
    rof=r*k*3.1415*.5;
    offset(r=rof,$fn=30)
    polygon(coords);
}

/////////////////////////////////////////////////////////

/////////////////// Furação do Nema 17 //////////////////

module furacao_nema17(diametro, profundidade, central = false){
    union(){
        if(central){
            circle(d = 23);
        }
        for (i =[0:3]){ 
            translate([31/1.414*cos(i*90+45),31/1.414*sin(i*90+45)])
            circle(d=diametro);
        }
    }
}

module furacao_out(diametro, profundidade, central = false){
    union(){
        if(central){
            circle(d = 15);
        }
        for (i =[0:3]){ 
            translate([15/1.414*cos(i*90+45),15/1.414*sin(i*90+45)])
            circle(d=diametro);
        }
    }
}

/////////////////////////////////////////////////////////

//////////////////// Engrenagem de Saída ///////////////

module hexagono(lado = 20) {
    // Calcula os vértices do hexágono
    polygon(points=[
        [lado*cos(0), lado*sin(0)],
        [lado*cos(60), lado*sin(60)],
        [lado*cos(120), lado*sin(120)],
        [lado*cos(180), lado*sin(180)],
        [lado*cos(240), lado*sin(240)],
        [lado*cos(300), lado*sin(300)]
    ]);
}


module output(){
    
    d1 = 35;
    echo("Diâmetro externo da engrenagem:", d1);
    ponto_base = 50;
    union(){
        
        
        
        //linear_extrude(7.3-4.5)
        //circle(d = d1);
        
        
        translate([0,0,ponto_base])
        linear_extrude(h-1)
        difference(){
            circle(d=d1);
            cycloid(r=r1,n=n2,k=1.15);
        }
        
        
        translate([0,0,ponto_base+h-1])
        
        linear_extrude(6)
        difference(){
            circle(d = 35);
            furacao_out(10, 10, central = false);
        }
        translate([0,0,ponto_base+h-1+6])
        
        linear_extrude(3)
        difference(){
            circle(d = 35);
            furacao_out(5, 10, central = false);
        }
        
    }
}



/////////////////////////////////////////////////////////

//////////////////// Engrenagem Cycloidal ///////////////

module dual_gear(){
    translate([0,0,20])
    union(){
        // segundo estágio
        linear_extrude(2*h1)
        difference(){
            cycloid(r=r1,n=n2-1,k=1);
            circle(d=23); // furo para rolamento
        }
        // primeiro estágio
        linear_extrude(h1)
        difference(){
            cycloid(r=r1,n=n-1,k=1);
            circle(d=23); // furo para rolamento
        }
    }
}

// o rolamento 608z tem 22mm de diametro externo


////////////////////////////////////////////////////////

/////////////////////// Base ///////////////////////////

module furo_chaveta(){
    // furação das chavetas
    /// primeiro conjunto 
    rotate([90,0,0])
    translate([0,h+4+(7.3/2),0])
    linear_extrude(35)
    square(size = 5, center = true);
    rotate([-90,0,0])
    translate([0,-h-4-(7.3/2),0])
    linear_extrude(35)
    square(size = 5, center = true);
    /// segundo conjunto  
    rotate([0,-90,0])
    translate([h+4+(7.3/2),0,0])
    linear_extrude(35)
    square(size = 5, center = true);
    rotate([0,90,0])
    translate([-h-4-(7.3/2),0,0])
    linear_extrude(35)
    square(size = 5, center = true);
}

module conjunto_base(){
    union(){
                  
        // suporte do rolamento
        translate([0,0,4+h])
        linear_extrude(7.3)
        difference(){
            circle(d = 60);
            circle(d = 56.3);
        }
        
        // engrenagem estacionária do primeiro estágio
        translate([0,0,4])
        linear_extrude(h)
        difference(){
            circle(d = 60);
            cycloid(r=r1,n=n,k=1.15);
            R=n*r;
            echo(R);
            echo(r);
        }
        // tampo da base
        translate([0,0,2])
        linear_extrude(2)
        difference(){
            circle(d = 60);
            furacao_nema17(5, central = true);
        }
        translate([0,0,0])
        linear_extrude(2)
        difference(){
            circle(d = 60);
            furacao_nema17(3.3, central = true);
        }
    }
}

// Montagem
//output();
dual_gear();
/*
// fazer os furos das chavedas na base
difference(){
    conjunto_base();
    furo_chaveta();
}
*/
///////////////////////////////////////////////////////
