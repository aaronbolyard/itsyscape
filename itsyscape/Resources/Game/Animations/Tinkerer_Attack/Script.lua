Animation "Tinkerer Attack" {
	Channel {
		Particles {
			duration = 1.5,
			attach = "wing.l.2",
			rotation = 'X_270',

			system = {
				numParticles = 20,
				texture = "Resources/Game/Animations/Tinkerer_Attack/Particle_Feather.png",

				emitters = {
					{
						type = "RadialEmitter",
						radius = { 0 },
						speed = { 10, 15 },
						xRange = { 1, 0.25 },
						yRange = { -0.25, 0.25 },
						zRange = { 0, 0 },
						acceleration = { 0, 0 }
					},
					{
						type = "RandomColorEmitter",
						colors = {
							{ 1, 1, 1, 0 }
						}
					},
					{
						type = "RandomLifetimeEmitter",
						age = { 0.5, 1.0 }
					},
					{
						type = "RandomScaleEmitter",
						scale = { 0.25, 0.5 }
					},
					{
						type = "RandomRotationEmitter",
						rotation = { 0, 360 },
						velocity = { 180, 360 }
					}
				},

				paths = {
					{
						type = "FadeInOutPath",
						fadeInPercent = { 0.3 },
						fadeOutPercent = { 0.7 },
						tween = { 'sineEaseOut' }
					}
				},

				emissionStrategy = {
					type = "RandomDelayEmissionStrategy",
					count = { 5, 10 },
					delay = { 0.125 },
					duration = { 1 }
				}
			}
		}
	},

	Channel {
		Particles {
			duration = 1.5,
			attach = "wing.l.2",
			rotation = 'X_270',

			system = {
				numParticles = 20,
				texture = "Resources/Game/Animations/Tinkerer_Attack/Particle_Bone.png",

				emitters = {
					{
						type = "RadialEmitter",
						radius = { 0 },
						speed = { 10, 15 },
						xRange = { 1, 0.25 },
						yRange = { -0.25, 0.25 },
						zRange = { 0, 0 },
						acceleration = { 0, 0 }
					},
					{
						type = "RandomColorEmitter",
						colors = {
							{ 1, 1, 1, 0 }
						}
					},
					{
						type = "RandomLifetimeEmitter",
						age = { 0.5, 1.0 }
					},
					{
						type = "RandomScaleEmitter",
						scale = { 0.25, 0.5 }
					},
					{
						type = "RandomRotationEmitter",
						rotation = { 0, 360 },
						velocity = { 180, 360 }
					}
				},

				paths = {
					{
						type = "FadeInOutPath",
						fadeInPercent = { 0.3 },
						fadeOutPercent = { 0.7 },
						tween = { 'sineEaseOut' }
					}
				},

				emissionStrategy = {
					type = "RandomDelayEmissionStrategy",
					count = { 5, 10 },
					delay = { 0.125 },
					duration = { 1 }
				}
			}
		}
	},

	Channel {
		Particles {
			duration = 1.5,
			attach = "wing.r.2",
			rotation = 'X_270',

			system = {
				numParticles = 20,
				texture = "Resources/Game/Animations/Tinkerer_Attack/Particle_Feather.png",

				emitters = {
					{
						type = "RadialEmitter",
						radius = { 0 },
						speed = { 10, 15 },
						xRange = { 1, 0.25 },
						yRange = { -0.25, 0.25 },
						zRange = { 0, 0 },
						acceleration = { 0, 0 }
					},
					{
						type = "RandomColorEmitter",
						colors = {
							{ 1, 1, 1, 0 }
						}
					},
					{
						type = "RandomLifetimeEmitter",
						age = { 0.5, 1.0 }
					},
					{
						type = "RandomScaleEmitter",
						scale = { 0.25, 0.5 }
					},
					{
						type = "RandomRotationEmitter",
						rotation = { 0, 360 },
						velocity = { 180, 360 }
					}
				},

				paths = {
					{
						type = "FadeInOutPath",
						fadeInPercent = { 0.3 },
						fadeOutPercent = { 0.7 },
						tween = { 'sineEaseOut' }
					}
				},

				emissionStrategy = {
					type = "RandomDelayEmissionStrategy",
					count = { 5, 10 },
					delay = { 0.125 },
					duration = { 1 }
				}
			}
		}
	},

	Channel {
		Particles {
			duration = 1.5,
			attach = "wing.r.2",
			rotation = 'X_270',

			system = {
				numParticles = 20,
				texture = "Resources/Game/Animations/Tinkerer_Attack/Particle_Bone.png",

				emitters = {
					{
						type = "RadialEmitter",
						radius = { 0 },
						speed = { 10, 15 },
						xRange = { 1, 0.25 },
						yRange = { -0.25, 0.25 },
						zRange = { 0, 0 },
						acceleration = { 0, 0 }
					},
					{
						type = "RandomColorEmitter",
						colors = {
							{ 1, 1, 1, 0 }
						}
					},
					{
						type = "RandomLifetimeEmitter",
						age = { 0.5, 1.0 }
					},
					{
						type = "RandomScaleEmitter",
						scale = { 0.25, 0.5 }
					},
					{
						type = "RandomRotationEmitter",
						rotation = { 0, 360 },
						velocity = { 180, 360 }
					}
				},

				paths = {
					{
						type = "FadeInOutPath",
						fadeInPercent = { 0.3 },
						fadeOutPercent = { 0.7 },
						tween = { 'sineEaseOut' }
					}
				},

				emissionStrategy = {
					type = "RandomDelayEmissionStrategy",
					count = { 5, 10 },
					delay = { 0.125 },
					duration = { 1 }
				}
			}
		}
	},

	Target {
		PlayAnimation "Resources/Game/Animations/Tinkerer_Attack/Animation.lanim"
	}
}
