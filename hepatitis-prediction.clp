(deffunction ProposeQuestion (?question $?allowed-values)
	(printout t ?question)
	(bind ?answer (read))
	(if (lexemep ?answer)
		then (bind ?answer (lowcase ?answer)))
	(while (not (member$ ?answer ?allowed-values)) do
		(printout t ?question)
		(bind ?answer (read))
		(if (lexemep ?answer)
			then (bind ?answer (lowcase ?answer))))
	?answer
)

(deffunction askCondition (?question)
	(bind ?response (ProposeQuestion ?question positive negative POSITIVE NEGATIVE Positive Negative p n))
	(if (or (eq ?response positive) (eq ?response POSITIVE) (eq ?response Positive) (eq ?response p))
		then positive
		else negative)
)

(defrule startUp
    (declare(salience 1))
	=>
	(printout t "Welcome to Hepatitis B Diagnosis Prediction Expert System. Please answer the following questions." crlf))
	
(defrule predictionGiven
	(program over)
	=>
	(printout t "Thank you for choosing this expert system. We hope you get better soon !" crlf))

(defrule askHBsAg
	(not(program over))
	=> 
	(assert(HBsAG(askCondition "HBsAg? (positive|negative): "))))

(defrule askAnti-HDV
	(not(program over))
    (HBsAG positive)
	=> 
	(assert(anti-HDV(askCondition "anti-HDV? (positive|negative): "))))

(defrule HepatitisBD
	(not(program over))
    (anti-HDV positive)
	=>
    (printout t "Prediction Result : Hepatitis B+D " crlf) 
	(assert(program over)))

(defrule askAnti-HBc
	(not(program over))
    (or (anti-HDV negative) (and (HBsAG negative) (anti-HBs ?)))
	=> 
	(assert(anti-HBc(askCondition "anti-HBc? (positive|negative): "))))

(defrule askAnti-HBs
	(not(program over))
    (or (and (HBsAG positive) (anti-HBc positive)) (HBsAG negative))
	=> 
	(assert(anti-HBs(askCondition "anti-HBs? (positive|negative): "))))

(defrule uncertainConfiguration
	(not(program over))
    (or (and (anti-HDV negative) (anti-HBc negative)) (and (anti-HDV negative) (anti-HBs positive)))
	=> 
    (printout t "Prediction Result : Uncertain Configuration " crlf) 
	(assert(program over)))

(defrule askIgMAnti-HBc
	(not(program over))
    (HBsAG positive)
    (anti-HBs negative)
	=> 
	(assert(igmAntiHBc(askCondition "IgM anti-HBc? (positive|negative): "))))

(defrule acuteInfection
	(not(program over))
    (igmAntiHBc positive)
	=> 
    (printout t "Prediction Result : Acute Infection " crlf) 
	(assert(program over)))

(defrule chronicInfection
	(not(program over))
    (igmAntiHBc negative)
	=> 
    (printout t "Prediction Result : Chronic Infection " crlf) 
	(assert(program over)))

(defrule cured
	(not(program over))
    (HBsAG negative)
    (anti-HBs positive)
    (anti-HBc positive)
	=> 
    (printout t "Prediction Result : Cured " crlf) 
	(assert(program over)))

(defrule Vaccinated
	(not(program over))
    (HBsAG negative)
    (anti-HBs positive)
    (anti-HBc negative)
	=> 
    (printout t "Prediction Result : Vaccinated " crlf) 
	(assert(program over)))

(defrule unclear
	(not(program over))
    (HBsAG negative)
    (anti-HBs negative)
    (anti-HBc positive)
	=> 
    (printout t "Prediction Result : Unclear (possible resolved) " crlf) 
	(assert(program over)))

(defrule suspicious
	(not(program over))
    (HBsAG negative)
    (anti-HBs negative)
    (anti-HBc negative)
	=> 
    (printout t "Prediction Result : Healthy not vaccinated or suspicious " crlf) 
	(assert(program over)))