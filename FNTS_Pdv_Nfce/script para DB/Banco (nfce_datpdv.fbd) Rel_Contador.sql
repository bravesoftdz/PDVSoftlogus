alter table CUPOM add contingencia varchar(1);
alter table CUPOM add gerado_nfce varchar(1);

create or alter procedure ST_CUPOM_INSERT (
    CODIGO varchar(50),
    NUMERO varchar(12),
    CCF varchar(12),
    ECF varchar(30),
    DATA date,
    HORA time,
    QTDE_ITEM integer,
    VALOR_PRODUTO numeric(15,2),
    VALOR_DESCONTO numeric(15,2),
    VALOR_ACRESCIMO numeric(15,2),
    VALOR_TOTAL numeric(15,2),
    VALOR_PAGO numeric(15,2),
    VALOR_TROCO numeric(15,2),
    COD_CLIENTE integer,
    CANCELADO integer,
    CPF_CONSUMIDOR varchar(20),
    NOME_CONSUMIDOR varchar(40),
    COD_VENDEDOR integer,
    COD_CAIXA integer,
    ECF_CAIXA varchar(3),
    contingencia varchar(1),
    gerado_nfce varchar(1))
as
begin
  Insert into CUPOM
    (codigo, numero, ccf, ecf, data, hora, qtde_item, valor_produto,
     valor_desconto, valor_acrescimo, valor_total, valor_pago,
     valor_troco, cod_cliente, cancelado, cpf_consumidor, NOME_CONSUMIDOR,
     cod_vendedor, cod_caixa, ecf_caixa, contingencia, gerado_nfce)
  values
    (:codigo, :numero, :ccf,  :ecf, :data, :hora, :qtde_item, :valor_produto,
     :valor_desconto, :valor_acrescimo, :valor_total, :valor_pago,
     :valor_troco, :cod_cliente, :cancelado, :cpf_consumidor, :nome_consumidor,
     :cod_vendedor, :cod_caixa, :ecf_caixa, :contingencia, :gerado_nfce);
  suspend;

end;

GRANT INSERT ON CUPOM TO PROCEDURE ST_CUPOM_INSERT;
GRANT EXECUTE ON PROCEDURE ST_CUPOM_INSERT TO SYSDBA;


